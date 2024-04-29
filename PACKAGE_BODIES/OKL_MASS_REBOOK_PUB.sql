--------------------------------------------------------
--  DDL for Package Body OKL_MASS_REBOOK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_MASS_REBOOK_PUB" AS
/* $Header: OKLPMRPB.pls 115.5 2003/01/28 22:55:05 dedey noship $*/

--Global Variables
  G_DEBUG       NUMBER := 1;
  G_INIT_NUMBER NUMBER := -9999;
  G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_MASS_REBOOK_PUB';
  G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PUB';

------------------------------------------------------------------------------
-- PROCEDURE build_and_get_contracts
--   This proecdure uses DYNAMIC SQL to get list of contracts from
--   selection criteria provided by user in OKL_MASS_RBK_CRITERIA
--   against REQUEST_NAME and inserts contract information to
--   OKL_RBK_SELECTED_CONTRACT table
--   It returns the list of contracts selected under present crietria
-- Calls:
-- Called by:
------------------------------------------------------------------------------
  PROCEDURE build_and_get_contracts(
                                    p_api_version        IN  NUMBER,
                                    p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                    x_return_status      OUT NOCOPY VARCHAR2,
                                    x_msg_count          OUT NOCOPY NUMBER,
                                    x_msg_data           OUT NOCOPY VARCHAR2,
                                    p_request_name       IN  OKL_MASS_RBK_CRITERIA.REQUEST_NAME%TYPE,
                                    p_mrbv_tbl           IN  mrbv_tbl_type,
                                    x_mstv_tbl           OUT NOCOPY mstv_tbl_type,
                                    x_rbk_count          OUT NOCOPY NUMBER
                                   ) IS

  l_api_name    VARCHAR2(35)    := 'build_and_get_contract';
  l_proc_name   VARCHAR2(35)    := 'BUILD_AND_GET_CONTRACT';
  l_api_version NUMBER          := 1.0;

  BEGIN
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

     --
     -- Get Statement from Selection criteria
     --
     okl_mass_rebook_pvt.build_and_get_contracts(
                                      p_api_version   => p_api_version,
                                      p_init_msg_list => p_init_msg_list,
                                      x_return_status => x_return_status,
                                      x_msg_count     => x_msg_count,
                                      x_msg_data      => x_msg_data,
                                      p_request_name  => p_request_name,
                                      p_mrbv_tbl      => p_mrbv_tbl,
                                      x_mstv_tbl      => x_mstv_tbl,
                                      x_rbk_count     => x_rbk_count
                                     );

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);


     RETURN;

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
  END build_and_get_contracts;

------------------------------------------------------------------------------
-- PROCEDURE apply_mass_rebook
--   This proecdure uses to apply mass rebook for contracts. It should be called
--   by those who does not have access to MASS REBOOK UI under OKL
--   This process also returns Stream generation trx number to caller
-- Calls:
-- Called by:
------------------------------------------------------------------------------

  PROCEDURE apply_mass_rebook(
                              p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_rbk_tbl            IN  rbk_tbl_type,
                              p_deprn_method_code  IN  FA_BOOKS.DEPRN_METHOD_CODE%TYPE,
                              p_in_service_date    IN  FA_BOOKS.DATE_PLACED_IN_SERVICE%TYPE,
                              p_life_in_months     IN  FA_BOOKS.LIFE_IN_MONTHS%TYPE,
                              p_basic_rate         IN  FA_BOOKS.BASIC_RATE%TYPE,
                              p_adjusted_rate      IN  FA_BOOKS.ADJUSTED_RATE%TYPE,
                              p_residual_value     IN  OKL_K_LINES_V.RESIDUAL_VALUE%TYPE,
                              p_strm_lalevl_tbl    IN  strm_lalevl_tbl_type,
                              x_stream_trx_tbl     OUT NOCOPY strm_trx_tbl_type
                             ) IS

  l_api_name    VARCHAR2(35)    := 'apply_mass_rebook';
  l_proc_name   VARCHAR2(35)    := 'APPLY_MASS_REBOOK';
  l_api_version NUMBER          := 1.0;

  BEGIN

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

     okl_mass_rebook_pvt.apply_mass_rebook(
                                           p_api_version       => p_api_version,
                                           p_init_msg_list     => p_init_msg_list,
                                           x_return_status     => x_return_status,
                                           x_msg_count         => x_msg_count,
                                           x_msg_data          => x_msg_data,
                                           p_rbk_tbl           => p_rbk_tbl,
                                           p_deprn_method_code => p_deprn_method_code,
                                           p_in_service_date   => p_in_service_date,
                                           p_life_in_months    => p_life_in_months,
                                           p_basic_rate        => p_basic_rate,
                                           p_adjusted_rate     => p_adjusted_rate,
                                           p_residual_value    => p_residual_value,
                                           p_strm_lalevl_tbl   => p_strm_lalevl_tbl,
                                           x_stream_trx_tbl    => x_stream_trx_tbl
                                          );

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
     END IF;


     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);


     RETURN;

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
  END apply_mass_rebook;

------------------------------------------------------------------------------
-- PROCEDURE apply_mass_rebook
--   This proecdure uses to apply mass rebook for contracts. It should be called
--   by those who does not have access to MASS REBOOK UI under OKL
-- Calls:
-- Called by:
------------------------------------------------------------------------------

 PROCEDURE apply_mass_rebook(
                             p_api_version        IN  NUMBER,
                             p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status      OUT NOCOPY VARCHAR2,
                             x_msg_count          OUT NOCOPY NUMBER,
                             x_msg_data           OUT NOCOPY VARCHAR2,
                             p_rbk_tbl            IN  rbk_tbl_type,
                             p_deprn_method_code  IN  FA_BOOKS.DEPRN_METHOD_CODE%TYPE,
                             p_in_service_date    IN  FA_BOOKS.DATE_PLACED_IN_SERVICE%TYPE,
                             p_life_in_months     IN  FA_BOOKS.LIFE_IN_MONTHS%TYPE,
                             p_basic_rate         IN  FA_BOOKS.BASIC_RATE%TYPE,
                             p_adjusted_rate      IN  FA_BOOKS.ADJUSTED_RATE%TYPE,
                             p_residual_value     IN  OKL_K_LINES_V.RESIDUAL_VALUE%TYPE,
                             p_strm_lalevl_tbl    IN  strm_lalevl_tbl_type
                            ) IS

  l_api_name    VARCHAR2(35)    := 'apply_mass_rebook';
  l_proc_name   VARCHAR2(35)    := 'APPLY_MASS_REBOOK';
  l_api_version NUMBER          := 1.0;

  BEGIN

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

     okl_mass_rebook_pvt.apply_mass_rebook(
                                           p_api_version       => p_api_version,
                                           p_init_msg_list     => p_init_msg_list,
                                           x_return_status     => x_return_status,
                                           x_msg_count         => x_msg_count,
                                           x_msg_data          => x_msg_data,
                                           p_rbk_tbl           => p_rbk_tbl,
                                           p_deprn_method_code => p_deprn_method_code,
                                           p_in_service_date   => p_in_service_date,
                                           p_life_in_months    => p_life_in_months,
                                           p_basic_rate        => p_basic_rate,
                                           p_adjusted_rate     => p_adjusted_rate,
                                           p_residual_value    => p_residual_value,
                                           p_strm_lalevl_tbl   => p_strm_lalevl_tbl
                                          );

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
     END IF;


     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);


     RETURN;

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
  END apply_mass_rebook;

------------------------------------------------------------------------------
-- PROCEDURE process_mass_rebook
--   This proecdure uses to apply mass rebook for contracts applied ON-LINE.
-- Calls:
-- Called by:
------------------------------------------------------------------------------
 PROCEDURE process_mass_rebook(
                               p_api_version        IN  NUMBER,
                               p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               x_msg_count          OUT NOCOPY NUMBER,
                               x_msg_data           OUT NOCOPY VARCHAR2,
                               p_request_name       IN  OKL_MASS_RBK_CRITERIA.REQUEST_NAME%TYPE
                              ) IS

  l_api_name    VARCHAR2(35)    := 'process_mass_rebook';
  l_proc_name   VARCHAR2(35)    := 'PROCESS_MASS_REBOOK';
  l_api_version NUMBER          := 1.0;

  BEGIN

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

     okl_mass_rebook_pvt.process_mass_rebook(
                                             p_api_version   => p_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data,
                                             p_request_name  => p_request_name
                                            );

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;


     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);


     RETURN;

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

   END process_mass_rebook;

------------------------------------------------------------------------------
-- PROCEDURE update_mass_rbk_contract
--   Call this process to update selected contracts. This process updates
--   selected_flag and status of contract provided as parameter
-- Calls:
-- Called by:
------------------------------------------------------------------------------
  PROCEDURE update_mass_rbk_contract(
                                     p_api_version                  IN  NUMBER,
                                     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                     x_return_status                OUT NOCOPY VARCHAR2,
                                     x_msg_count                    OUT NOCOPY NUMBER,
                                     x_msg_data                     OUT NOCOPY VARCHAR2,
                                     p_mstv_tbl                     IN  MSTV_TBL_TYPE,
                                     x_mstv_tbl                     OUT NOCOPY MSTV_TBL_TYPE
                                    ) IS

  l_api_name    VARCHAR2(35)    := 'update_mass_rbk_contract';
  l_proc_name   VARCHAR2(35)    := 'UPDATE_MASS_RBK_CONTRACT';
  l_api_version NUMBER          := 1.0;

  BEGIN

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

     okl_mass_rebook_pvt.update_mass_rbk_contract(
                                                 p_api_version      => p_api_version,
                                                 p_init_msg_list    => p_init_msg_list,
                                                 x_return_status    => x_return_status,
                                                 x_msg_count        => x_msg_count,
                                                 x_msg_data         => x_msg_data,
                                                 p_mstv_tbl         => p_mstv_tbl,
                                                 x_mstv_tbl         => x_mstv_tbl
                                                );

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);


     RETURN;

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

  END update_mass_rbk_contract;

------------------------------------------------------------------------------
-- PROCEDURE mass_rebook_after_yield
--   This proecdure gets started after yields come back from SuperTrump and
--   proceed with the rest of Mass Rebook process
-- Calls:
-- Called by:
------------------------------------------------------------------------------
  PROCEDURE mass_rebook_after_yield(
                                    p_api_version        IN  NUMBER,
                                    p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                    x_return_status      OUT NOCOPY VARCHAR2,
                                    x_msg_count          OUT NOCOPY NUMBER,
                                    x_msg_data           OUT NOCOPY VARCHAR2,
                                    p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE
                                   ) IS

  l_api_name    VARCHAR2(35)    := 'mass_rebook_after_yield';
  l_proc_name   VARCHAR2(35)    := 'MASS_REBOOK_AFTER_YIELD';
  l_api_version NUMBER          := 1.0;

  BEGIN

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

     okl_mass_rebook_pvt.mass_rebook_after_yield(
                                                 p_api_version      => p_api_version,
                                                 p_init_msg_list    => p_init_msg_list,
                                                 x_return_status    => x_return_status,
                                                 x_msg_count        => x_msg_count,
                                                 x_msg_data         => x_msg_data,
                                                 p_chr_id           => p_chr_id
                                                );

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);


     RETURN;

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

  END mass_rebook_after_yield;

END OKL_MASS_REBOOK_PUB;

/
