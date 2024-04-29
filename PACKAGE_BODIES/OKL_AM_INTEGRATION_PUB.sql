--------------------------------------------------------
--  DDL for Package Body OKL_AM_INTEGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_INTEGRATION_PUB" AS
/* $Header: OKLPKRBB.pls 120.1 2005/09/01 21:24:14 rmunjulu noship $ */

  -- Global Private Variables and Types

-- Start of comments
--
-- Procedure Name       : cancel_termination_quotes
-- Description          : Invalidates all the termination quotes
--                      : for the contract
-- Business Rules       :
-- Parameters           : contract_id and quote_id which caused the rebook process
-- Version              : 1.0
-- End of comments

  PROCEDURE cancel_termination_quotes  (p_api_version   IN          NUMBER,
                                        p_init_msg_list IN          VARCHAR2 DEFAULT G_FALSE,
                                        p_khr_id        IN          NUMBER,
                                        p_source_trx_id IN          NUMBER ,
                                        p_source        IN          VARCHAR2 DEFAULT NULL, -- rmunjulu 4508497
                                        x_return_status OUT NOCOPY  VARCHAR2,
                                        x_msg_count     OUT NOCOPY NUMBER,
                                        x_msg_data      OUT NOCOPY VARCHAR2) IS

       lp_source_trx_id              NUMBER           := p_source_trx_id;
       lp_khr_id                NUMBER           := p_khr_id;
       l_return_status          VARCHAR2(1)      := OKL_API.G_RET_STS_SUCCESS;
       l_program_name  CONSTANT VARCHAR2(61)     := 'cancel_termination_quotes';
       l_api_name      CONSTANT VARCHAR2(61)     := G_PKG_NAME||'.'||l_program_name;

       -- rmunjulu 4508497
       lp_source VARCHAR2(300) := p_source;

  BEGIN
    -- create a save point with the procedure name
    SAVEPOINT l_program_name;
    -- call the process pvt wrapper
    OKL_AM_INTEGRATION_PVT.cancel_termination_quotes(p_api_version   => p_api_version,
                                                     p_init_msg_list => p_init_msg_list,
                                                     p_khr_id        => lp_khr_id,
                                                     p_source_trx_id => lp_source_trx_id,
                                                     p_source        => lp_source, -- rmunjulu 4508497
                                                     x_return_status => l_return_status,
                                                     x_msg_count     => x_msg_count,
                                                     x_msg_data      => x_msg_data);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      ROLLBACK TO l_program_name;
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO l_program_name;
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
      ROLLBACK TO l_program_name;
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END cancel_termination_quotes;

END  OKL_AM_INTEGRATION_PUB;

/
