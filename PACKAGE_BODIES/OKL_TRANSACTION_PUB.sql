--------------------------------------------------------
--  DDL for Package Body OKL_TRANSACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRANSACTION_PUB" AS
/* $Header: OKLPTXNB.pls 115.1 2002/08/19 22:05:30 dedey noship $*/

-- Global Variables
   G_DEBUG       NUMBER := 1;
   G_INIT_NUMBER NUMBER := -9999;
   G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_CREATE_TRANSACTION_PUB';
   G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
   G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PUB';

--   subtype tcnv_rec_type IS OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;
   subtype stmv_rec_type IS OKL_STREAMS_PUB.stmv_rec_type;
   subtype selv_rec_type IS OKL_STREAMS_PUB.selv_rec_type;
   subtype selv_tbl_type IS OKL_STREAMS_PUB.selv_tbl_type;
   subtype khrv_rec_type IS OKL_CONTRACT_PUB.khrv_rec_type;
   subtype chrv_rec_type IS OKL_OKC_MIGRATION_PVT.chrv_rec_type;
   subtype clev_tbl_type IS OKL_OKC_MIGRATION_PVT.clev_tbl_type;
   subtype klev_tbl_type IS OKL_CONTRACT_PUB.klev_tbl_type;
   subtype rulv_rec_type IS OKL_RULE_PUB.rulv_rec_type;
   subtype rulv_tbl_type IS OKL_RULE_PUB.rulv_tbl_type;
   subtype rgpv_rec_type IS OKL_RULE_PUB.rgpv_rec_type;
   subtype cvmv_rec_type IS OKL_VERSION_PUB.cvmv_rec_type;


------------------------------------------------------------------------------
-- PROCEDURE create_transaction
--
--  This procedure creates Transaction as a first step to REBOOKing
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE create_transaction(
                          p_api_version        IN  NUMBER,
                          p_init_msg_list      IN  VARCHAR2,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_msg_count          OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2,
                          p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_new_chr_id         IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_reason_code        IN  VARCHAR2,
                          p_description        IN  VARCHAR2,
                          p_trx_date           IN  DATE,
                          p_trx_type           IN  VARCHAR2, -- 'REBOOK' or 'SPLIT'
                          x_tcnv_rec           OUT NOCOPY tcnv_rec_type
                         ) IS

  l_api_name    VARCHAR2(35)    := 'create_transaction';
  l_proc_name   VARCHAR2(35)    := 'CREATE_TRANSACTION';
  l_api_version CONSTANT NUMBER := 1;

  l_tcnv_rec        tcnv_rec_type;
  l_out_tcnv_rec    tcnv_rec_type;

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

      okl_transaction_pvt.create_transaction(
                                             p_api_version    => p_api_version,
                                             p_init_msg_list  => p_init_msg_list,
                                             x_return_status  => x_return_status,
                                             x_msg_count      => x_msg_count,
                                             x_msg_data       => x_msg_data,
                                             p_chr_id         => p_chr_id,
                                             p_new_chr_id     => p_new_chr_id,
                                             p_reason_code    => p_reason_code,
                                             p_description    => p_description,
                                             p_trx_date       => p_trx_date,
                                             p_trx_type       => p_trx_type,
                                             x_tcnv_rec       => x_tcnv_rec
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

  END create_transaction;

------------------------------------------------------------------------------
-- PROCEDURE update_trx_status
--
--  This procedure updates Transaction Status for a transaction
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE update_trx_status(
                              p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                              p_status             IN  VARCHAR2,
                              x_tcnv_rec           OUT NOCOPY tcnv_rec_type
                             ) IS

  l_api_name    VARCHAR2(35)    := 'update_trx_status';
  l_proc_name   VARCHAR2(35)    := 'UPDATE_TRX_STATUS';
  l_api_version CONSTANT NUMBER := 1;

  BEGIN

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

      okl_transaction_pvt.update_trx_status(
                                            p_api_version        => p_api_version,
                                            p_init_msg_list      => p_init_msg_list,
                                            x_return_status      => x_return_status,
                                            x_msg_count          => x_msg_count,
                                            x_msg_data           => x_msg_data,
                                            p_chr_id             => p_chr_id,
                                            p_status             => p_status,
                                            x_tcnv_rec           => x_tcnv_rec
                                           );
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
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
  END update_trx_status;


  ------------------------------------------------------------------------------
  -- PROCEDURE abandon_revisions
  --
  --  This procedure abandons contracts with under Revisions
  --
  -- Calls:
  -- Called By:
  ------------------------------------------------------------------------------
   PROCEDURE abandon_revisions(
                                  p_api_version        IN  NUMBER,
                                  p_init_msg_list      IN  VARCHAR2,
                                  x_return_status      OUT NOCOPY VARCHAR2,
                                  x_msg_count          OUT NOCOPY NUMBER,
                                  x_msg_data           OUT NOCOPY VARCHAR2,
                                  p_rev_tbl            IN  rev_tbl_type,
                                  p_contract_status    IN  VARCHAR2,
  		                p_tsu_code             IN  VARCHAR2) IS

    l_api_name    VARCHAR2(35)    := 'abandon_revisions';
    l_proc_name   VARCHAR2(35)    := 'UPDATE_TRX_STATUS';
    l_api_version CONSTANT NUMBER := 1;

    BEGIN


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
          okl_transaction_pvt.abandon_revisions(
                                p_api_version        => p_api_version,
                                p_init_msg_list      => p_init_msg_list,
                                x_return_status      => x_return_status,
                                x_msg_count          => x_msg_count,
                                x_msg_data           => x_msg_data,
                                p_rev_tbl            => p_rev_tbl,
                                p_contract_status    => p_contract_status,
  		                p_tsu_code           => p_tsu_code);

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
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
    END abandon_revisions;

END OKL_TRANSACTION_PUB;

/
