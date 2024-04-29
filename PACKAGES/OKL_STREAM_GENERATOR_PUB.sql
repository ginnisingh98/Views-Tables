--------------------------------------------------------
--  DDL for Package OKL_STREAM_GENERATOR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_STREAM_GENERATOR_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSGPS.pls 115.9 2003/10/15 21:37:01 ssiruvol noship $ */

  -----------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  -----------------------------------------------------------------------------
  G_PKG_NAME              CONSTANT VARCHAR2(200) := 'OKL_STREAM_GENERATOR_PUB';
  G_APP_NAME              CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_API_TYPE              CONSTANT VARCHAR2(4)   := '_PUB';
  G_API_VERSION           CONSTANT NUMBER        := 1;
  G_FALSE                 CONSTANT VARCHAR2(30)  := OKL_API.G_FALSE;


  G_EXC_NAME_ERROR        CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR  CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_UNEXPECTED_ERROR      CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXP_ERROR';
  G_SQLCODE_TOKEN         CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN         CONSTANT VARCHAR2(200) := 'SQLERRM';

  ---------------------------------------------------------------------------
  -- PROGRAM UNITS
  ---------------------------------------------------------------------------

  PROCEDURE generate_streams( p_api_version                IN         NUMBER,
                              p_init_msg_list              IN         VARCHAR2,
                              p_khr_id                     IN         NUMBER,
                              p_compute_rates              IN  VARCHAR2 DEFAULT OKL_API.G_TRUE,
                              p_generation_type            IN  VARCHAR2 DEFAULT 'FULL',
                              p_reporting_book_class       IN  VARCHAR2 DEFAULT NULL,
                              x_contract_rates             OUT NOCOPY OKL_STREAM_GENERATOR_PVT.rate_rec_type,
                              x_return_status              OUT NOCOPY VARCHAR2,
                              x_msg_count                  OUT NOCOPY NUMBER,
                              x_msg_data                   OUT NOCOPY VARCHAR2);

  PROCEDURE generate_streams( p_api_version                IN  NUMBER,
                              p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              p_khr_id                     IN  NUMBER,
                              p_compute_irr                IN  VARCHAR2 DEFAULT OKL_API.G_TRUE,
                              p_generation_type            IN  VARCHAR2 DEFAULT 'FULL',
                              p_reporting_book_class       IN  VARCHAR2 DEFAULT NULL,
                              x_pre_tax_irr                OUT NOCOPY NUMBER,
                              x_return_status              OUT NOCOPY VARCHAR2,
                              x_msg_count                  OUT NOCOPY NUMBER,
                              x_msg_data                   OUT NOCOPY VARCHAR2);

   PROCEDURE  GEN_VAR_INT_SCHEDULE(  p_api_version         IN      NUMBER,
                                   p_init_msg_list       IN      VARCHAR2,
                                   p_khr_id              IN      NUMBER,
                                   p_purpose_code        IN      VARCHAR2,
                                   x_return_status       OUT NOCOPY VARCHAR2,
                                   x_msg_count           OUT NOCOPY NUMBER,
                                   x_msg_data            OUT NOCOPY VARCHAR2);

END okl_stream_generator_pub;

 

/
