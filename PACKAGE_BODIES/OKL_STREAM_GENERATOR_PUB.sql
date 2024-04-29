--------------------------------------------------------
--  DDL for Package Body OKL_STREAM_GENERATOR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STREAM_GENERATOR_PUB" AS
/* $Header: OKLPSGPB.pls 115.9 2003/10/15 21:36:44 ssiruvol noship $ */

  PROCEDURE generate_streams( p_api_version                IN         NUMBER,
                              p_init_msg_list              IN         VARCHAR2,
                              p_khr_id                     IN         NUMBER,
                              p_compute_rates              IN  VARCHAR2 DEFAULT OKL_API.G_TRUE,
                              p_generation_type            IN  VARCHAR2 DEFAULT 'FULL',
                              p_reporting_book_class       IN  VARCHAR2 DEFAULT NULL,
                              x_contract_rates             OUT NOCOPY OKL_STREAM_GENERATOR_PVT.rate_rec_type,
                              x_return_status              OUT NOCOPY VARCHAR2,
                              x_msg_count                  OUT NOCOPY NUMBER,
                              x_msg_data                   OUT NOCOPY VARCHAR2) IS

    l_api_name          CONSTANT VARCHAR2(30)  := 'generate_streams';
    lx_return_status    VARCHAR2(1);

  BEGIN

    lx_return_status := okl_api.start_activity(p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
                                               p_init_msg_list => p_init_msg_list,
                                               l_api_version   => G_API_VERSION,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => lx_return_status);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- call to PVT API
    okl_stream_generator_pvt.generate_streams( p_api_version     => G_API_VERSION,
                                               p_init_msg_list   => G_FALSE,
                                               p_khr_id          => p_khr_id,
                                               p_compute_rates     => p_compute_rates,
                                               p_generation_type => p_generation_type,
                                               p_reporting_book_class => p_reporting_book_class,
                                               x_contract_rates     => x_contract_rates,
                                               x_return_status   => lx_return_status,
                                               x_msg_count       => x_msg_count,
                                               x_msg_data        => x_msg_data);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    okl_api.end_activity(x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data);

    x_return_status  :=  lx_return_status;


  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.handle_exceptions(p_api_name  => l_api_name,
                                                   p_pkg_name  => G_PKG_NAME,
                                                   p_exc_name  => G_EXC_NAME_ERROR,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data  => x_msg_data,
                                                   p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.handle_exceptions(p_api_name  => l_api_name,
                                                   p_pkg_name  => G_PKG_NAME,
                                                   p_exc_name  => G_EXC_NAME_UNEXP_ERROR,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data  => x_msg_data,
                                                   p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      x_return_status := okl_api.handle_exceptions(p_api_name  => l_api_name,
                                                   p_pkg_name  => G_PKG_NAME,
                                                   p_exc_name  => 'OTHERS',
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data  => x_msg_data,
                                                   p_api_type  => G_API_TYPE);
  END generate_streams;


  PROCEDURE generate_streams( p_api_version                IN  NUMBER,
                              p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              p_khr_id                     IN  NUMBER,
                              p_compute_irr                IN  VARCHAR2 DEFAULT OKL_API.G_TRUE,
                              p_generation_type            IN  VARCHAR2 DEFAULT 'FULL',
                              p_reporting_book_class       IN  VARCHAR2 DEFAULT NULL,
                              x_pre_tax_irr                OUT NOCOPY NUMBER,
                              x_return_status              OUT NOCOPY VARCHAR2,
                              x_msg_count                  OUT NOCOPY NUMBER,
                              x_msg_data                   OUT NOCOPY VARCHAR2) IS

    l_api_name          CONSTANT VARCHAR2(30)  := 'generate_streams';
    lx_return_status    VARCHAR2(1);

  BEGIN

    lx_return_status := okl_api.start_activity(p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
                                               p_init_msg_list => p_init_msg_list,
                                               l_api_version   => G_API_VERSION,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => lx_return_status);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- call to PVT API
    okl_stream_generator_pvt.generate_streams( p_api_version     => G_API_VERSION,
                                               p_init_msg_list   => G_FALSE,
                                               p_khr_id          => p_khr_id,
                                               p_compute_irr     => p_compute_irr,
                                               p_generation_type => p_generation_type,
                                               p_reporting_book_class => p_reporting_book_class,
                                               x_pre_tax_irr     => x_pre_tax_irr,
                                               x_return_status   => lx_return_status,
                                               x_msg_count       => x_msg_count,
                                               x_msg_data        => x_msg_data);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    okl_api.end_activity(x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data);

    x_return_status  :=  lx_return_status;


  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.handle_exceptions(p_api_name  => l_api_name,
                                                   p_pkg_name  => G_PKG_NAME,
                                                   p_exc_name  => G_EXC_NAME_ERROR,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data  => x_msg_data,
                                                   p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.handle_exceptions(p_api_name  => l_api_name,
                                                   p_pkg_name  => G_PKG_NAME,
                                                   p_exc_name  => G_EXC_NAME_UNEXP_ERROR,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data  => x_msg_data,
                                                   p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      x_return_status := okl_api.handle_exceptions(p_api_name  => l_api_name,
                                                   p_pkg_name  => G_PKG_NAME,
                                                   p_exc_name  => 'OTHERS',
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data  => x_msg_data,
                                                   p_api_type  => G_API_TYPE);
  END generate_streams;

   PROCEDURE  GEN_VAR_INT_SCHEDULE(  p_api_version         IN      NUMBER,
                                   p_init_msg_list       IN      VARCHAR2,
                                   p_khr_id              IN      NUMBER,
                                   p_purpose_code        IN      VARCHAR2,
                                   x_return_status       OUT NOCOPY VARCHAR2,
                                   x_msg_count           OUT NOCOPY NUMBER,
                                   x_msg_data            OUT NOCOPY VARCHAR2) IS

   BEGIN

       OKL_STREAM_GENERATOR_PVT.GEN_VAR_INT_SCHEDULE(
                                   p_api_version         => p_api_version,
                                   p_init_msg_list       => p_init_msg_list,
                                   p_khr_id              => p_khr_id,
                                   p_purpose_code        => p_purpose_code,
                                   x_return_status       => x_return_status,
                                   x_msg_count           => x_msg_count,
                                   x_msg_data            => x_msg_data);

   END GEN_VAR_INT_SCHEDULE;

END okl_stream_generator_pub;

/
