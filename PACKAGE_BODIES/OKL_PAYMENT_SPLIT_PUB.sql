--------------------------------------------------------
--  DDL for Package Body OKL_PAYMENT_SPLIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAYMENT_SPLIT_PUB" AS
/* $Header: OKLPPMSB.pls 115.1 2003/11/12 22:26:32 avsingh noship $*/

-- Global Variables
   G_INIT_NUMBER NUMBER := -9999;
   G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_PAYMENT_SPLIT_PUB';
   G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
   G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PUB';


   subtype rgpv_rec_type IS OKL_RULE_PUB.rgpv_rec_type;
   subtype rulv_rec_type IS OKL_RULE_PUB.rulv_rec_type;
   subtype rgpv_tbl_type IS OKL_RULE_PUB.rgpv_tbl_type;
   subtype rulv_tbl_type IS OKL_RULE_PUB.rulv_tbl_type;

------------------------------------------------------------------------------
-- PROCEDURE generate_line_payments
--
--  This procedure proportion-ed the payments accross Financial Asset Top Line
--  and Fee Top Line. It returns the information in a table. It does not
--  create any payment to the contract
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE generate_line_payments(
                          p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_payment_type  IN  VARCHAR2,
                          p_amount        IN  NUMBER,
                          p_start_date    IN  DATE,
                          p_period        IN  NUMBER,
                          p_frequency     IN  VARCHAR2,
                          x_strm_tbl      OUT NOCOPY okl_mass_rebook_pub.strm_lalevl_tbl_type
                         ) IS

  l_api_name           VARCHAR2(35)    := 'generate_line_payments';
  l_proc_name          VARCHAR2(35)    := 'generate_line_payments';
  l_api_version        CONSTANT NUMBER := 1;
  l_precision          FND_CURRENCIES.PRECISION%TYPE;

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


      okl_payment_split_pvt.generate_line_payments(
                          p_api_version   => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_chr_id        => p_chr_id,
                          p_payment_type  => p_payment_type,
                          p_amount        => p_amount,
                          p_start_date    => p_start_date,
                          p_period        => p_period,
                          p_frequency     => p_frequency,
                          x_strm_tbl      => x_strm_tbl
                         );
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

    --Call End Activity
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

  END generate_line_payments;

END OKL_PAYMENT_SPLIT_PUB;

/
